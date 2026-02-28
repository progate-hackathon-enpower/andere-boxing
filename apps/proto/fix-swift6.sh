#!/bin/bash

# Swift 6 strict concurrency の設定を Minimal に変更するスクリプト

XCODEPROJ="../andere-boxing/andere-boxing.xcodeproj/project.pbxproj"

if [ ! -f "$XCODEPROJ" ]; then
    echo "❌ エラー: $XCODEPROJ が見つかりません"
    exit 1
fi

echo "🔧 Xcode プロジェクトの Strict Concurrency Checking を Minimal に設定中..."

# project.pbxproj ファイルをバックアップ
cp "$XCODEPROJ" "${XCODEPROJ}.backup"

# SWIFT_STRICT_CONCURRENCY の設定を探して更新
# 存在しない場合は追加する必要があるため、現在の設定を確認
if grep -q "SWIFT_STRICT_CONCURRENCY" "$XCODEPROJ"; then
    echo "🔍 既存の SWIFT_STRICT_CONCURRENCY 設定を更新中..."
    sed -i '' 's/SWIFT_STRICT_CONCURRENCY = complete;/SWIFT_STRICT_CONCURRENCY = minimal;/g' "$XCODEPROJ"
    sed -i '' 's/SWIFT_STRICT_CONCURRENCY = targeted;/SWIFT_STRICT_CONCURRENCY = minimal;/g' "$XCODEPROJ"
else
    echo "ℹ️  SWIFT_STRICT_CONCURRENCY 設定が見つかりません"
    echo "   Xcode で手動設定が必要です："
    echo "   Build Settings > Strict Concurrency Checking > Minimal"
fi

echo ""
echo "✅ 完了しました"
echo ""
echo "次のステップ："
echo "1. Xcode でプロジェクトを開く"
echo "2. Build Settings で 'Strict Concurrency Checking' を確認"
echo "3. 'Minimal' に設定されていることを確認"
echo "4. ⌘ + B でビルドを実行"
