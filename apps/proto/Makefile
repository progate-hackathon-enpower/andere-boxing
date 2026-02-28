# Protocol Buffers Swift Code Generation Makefile

# 出力ディレクトリ
GENERATED_DIR := ../andere-boxing/andere-boxing/Generated
PROTO_FILES := $(wildcard *.proto)

# protoc コマンド
PROTOC := protoc
PROTOC_GEN_SWIFT := protoc-gen-swift

# Swift 生成オプション (Swift 6 concurrency 対応)
SWIFT_OUT_OPTS := Visibility=Public,FileNaming=PathToUnderscores

# デフォルトターゲット
.PHONY: all
all: generate

# Swift コードを生成
.PHONY: generate
generate: check-deps
	@echo "📦 Protocol Buffers から Swift コードを生成中..."
	@mkdir -p $(GENERATED_DIR)
	@$(PROTOC) --swift_out=$(GENERATED_DIR) --swift_opt=$(SWIFT_OUT_OPTS) $(PROTO_FILES)
	@echo "🔧 Swift 6 対応パッチを適用中..."
	@for file in $(GENERATED_DIR)/*.pb.swift; do \
		if [ -f "$$file" ]; then \
			sed -i '' 's/^import SwiftProtobuf$$/@preconcurrency import SwiftProtobuf/' "$$file"; \
			sed -i '' 's/^struct \(AndereBoxing_[^:]*\): SwiftProtobuf\.Message/@available(*, unavailable)\nextension \1: @unchecked Sendable {}\n\nstruct \1: SwiftProtobuf.Message/' "$$file"; \
		fi \
	done
	@echo "✅ 生成完了: $(GENERATED_DIR)/"
	@ls -lh $(GENERATED_DIR)

# 生成されたファイルを削除
.PHONY: clean
clean:
	@echo "🗑️  生成されたファイルを削除中..."
	@rm -rf $(GENERATED_DIR)/*.pb.swift
	@echo "✅ 削除完了"

# 依存関係をチェック
.PHONY: check-deps
check-deps:
	@command -v $(PROTOC) >/dev/null 2>&1 || { \
		echo "❌ エラー: protoc がインストールされていません"; \
		echo "💡 以下のコマンドでインストールしてください:"; \
		echo "   make install-deps"; \
		exit 1; \
	}
	@command -v $(PROTOC_GEN_SWIFT) >/dev/null 2>&1 || { \
		echo "❌ エラー: protoc-gen-swift がインストールされていません"; \
		echo "💡 以下のコマンドでインストールしてください:"; \
		echo "   make install-deps"; \
		exit 1; \
	}
	@echo "✅ 依存関係 OK"

# Homebrew で依存関係をインストール（macOS のみ）
.PHONY: install-deps
install-deps:
	@echo "📥 Protocol Buffers ツールをインストール中..."
	@command -v brew >/dev/null 2>&1 || { \
		echo "❌ エラー: Homebrew がインストールされていません"; \
		echo "💡 https://brew.sh からインストールしてください"; \
		exit 1; \
	}
	brew install protobuf swift-protobuf
	@echo "✅ インストール完了"

# バージョン情報を表示
.PHONY: version
version:
	@echo "protoc version:"
	@$(PROTOC) --version || echo "protoc not installed"
	@echo "\nswift-protobuf version:"
	@$(PROTOC_GEN_SWIFT) --version || echo "protoc-gen-swift not installed"

# ヘルプを表示
.PHONY: help
help:
	@echo "Protocol Buffers Swift Code Generation"
	@echo ""
	@echo "使用可能なターゲット:"
	@echo "  make generate      - Protocol Buffers から Swift コードを生成"
	@echo "  make clean         - 生成されたファイルを削除"
	@echo "  make install-deps  - 必要なツールをインストール (Homebrew)"
	@echo "  make check-deps    - 依存関係がインストールされているか確認"
	@echo "  make version       - インストールされているツールのバージョンを表示"
	@echo "  make help          - このヘルプメッセージを表示"
	@echo ""
	@echo "使用例:"
	@echo "  make               - Swift コードを生成 (デフォルト)"
	@echo "  make clean         - 生成されたファイルを削除"
