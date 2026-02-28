/**
 * EKS Kubernetes API クライアント
 *
 * Lambda 環境: AWS IAM 認証で EKS API に直接アクセス
 * ローカル環境: kubectl proxy (http://localhost:8001) にフォールバック
 */

import { EKSClient, DescribeClusterCommand } from "@aws-sdk/client-eks";
import { STSClient } from "@aws-sdk/client-sts";
import { SignatureV4 } from "@smithy/signature-v4";
import { Sha256 } from "@aws-crypto/sha256-js";
import https from "node:https";

interface EksClusterInfo {
  endpoint: string;
  ca: string;
}

/** EKS Bearer token を生成（aws-iam-authenticator 互換） */
async function getEksToken(clusterName: string): Promise<string> {
  const sts = new STSClient({});
  const region = process.env.AWS_REGION ?? "ap-northeast-1";
  const stsHost = `sts.${region}.amazonaws.com`;

  const signer = new SignatureV4({
    service: "sts",
    region,
    credentials: sts.config.credentials,
    sha256: Sha256,
  });

  const request = {
    method: "GET",
    protocol: "https:",
    hostname: stsHost,
    path: "/",
    query: {
      Action: "GetCallerIdentity",
      Version: "2011-06-15",
      "X-Amz-Expires": "60",
    },
    headers: {
      host: stsHost,
      "x-k8s-aws-id": clusterName,
    },
  };

  const signed = await signer.presign(request, { expiresIn: 60 });

  const signedUrl =
    `https://${signed.hostname}${signed.path}?` +
    Object.entries(signed.query as Record<string, string>)
      .map(([k, v]) => `${encodeURIComponent(k)}=${encodeURIComponent(v)}`)
      .join("&");

  // k8s.io/client-go 互換: "k8s-aws-v1." + base64url(presigned URL)
  return (
    "k8s-aws-v1." +
    Buffer.from(signedUrl).toString("base64url").replace(/=+$/, "")
  );
}

export class EksClient {
  private clusterName: string | null;
  private clusterInfo: EksClusterInfo | null = null;

  constructor(clusterName?: string) {
    this.clusterName = clusterName ?? null;
  }

  /** EKS クラスタ情報をキャッシュ付きで取得 */
  private async getClusterInfo(): Promise<EksClusterInfo> {
    if (this.clusterInfo) return this.clusterInfo;

    const eks = new EKSClient({});
    const res = await eks.send(
      new DescribeClusterCommand({ name: this.clusterName! }),
    );
    this.clusterInfo = {
      endpoint: res.cluster!.endpoint!,
      ca: res.cluster!.certificateAuthority!.data!,
    };
    return this.clusterInfo;
  }

  /** Kubernetes API にリクエストを送る */
  async request(path: string, options: RequestInit = {}): Promise<Response> {
    // ローカル: kubectl proxy 経由
    if (!this.clusterName) {
      const proxyUrl = process.env.K8S_PROXY_URL ?? "http://localhost:8001";
      return fetch(`${proxyUrl}${path}`, {
        ...options,
        headers: {
          "Content-Type": "application/json",
          ...options.headers,
        },
      });
    }

    // Lambda: EKS API 直接（EKS CA 証明書を使って TLS 検証）
    const cluster = await this.getClusterInfo();
    const token = await getEksToken(this.clusterName);

    const url = new URL(`${cluster.endpoint}${path}`);
    const body = options.body != null ? String(options.body) : undefined;

    return new Promise<Response>((resolve, reject) => {
      const req = https.request(
        {
          hostname: url.hostname,
          port: 443,
          path: url.pathname + url.search,
          method: options.method ?? "GET",
          ca: Buffer.from(cluster.ca, "base64"),
          headers: {
            Authorization: `Bearer ${token}`,
            "Content-Type": "application/json",
            ...(options.headers as Record<string, string>),
          },
        },
        (res) => {
          const chunks: Buffer[] = [];
          res.on("data", (chunk: Buffer) => chunks.push(chunk));
          res.on("end", () => {
            const data = Buffer.concat(chunks).toString();
            resolve(
              new Response(data, {
                status: res.statusCode ?? 500,
                headers: res.headers as Record<string, string>,
              }),
            );
          });
        },
      );
      req.on("error", reject);
      if (body) req.write(body);
      req.end();
    });
  }
}
