$BASE = "http://localhost:8899"

# 重置统计
curl.exe -s -X POST "$BASE/ai/stats/reset" | Out-Null

# ===== A 类：知识库内问题（10 条）=====
$A = @(
    "张三的工作经历是什么",
    "谁在阿里巴巴工作过",
    "谁会 Rust",
    "王五精通什么技术",
    "有没有做 NLP 的候选人",
    "李四擅长什么编程语言",
    "谁有深度学习经验",
    "张三在哪些公司工作过",
    "王五的教育背景是什么",
    "谁会 Go 语言"
)

Write-Host "`n===== A 类（知识库内）=====" -ForegroundColor Green
foreach ($q in $A) {
    curl.exe -s --get "$BASE/ai/chat" --data-urlencode "msg=$q" --data-urlencode "conversationId=testA" | Out-Null
    Write-Host "  ✓ $q"
}

# ===== B 类：无关问题（10 条）=====
$B = @(
    "量子纠缠的数学基础是什么",
    "帮我写一首关于春天的诗",
    "明天北京天气怎么样",
    "如何做红烧肉",
    "简述相对论的基本原理",
    "推荐几本好看的小说",
    "股票市场怎么入门",
    "如何减肥最快",
    "解释一下区块链技术",
    "世界上最高的山是哪个"
)

Write-Host "`n===== B 类（无关）=====" -ForegroundColor Magenta
foreach ($q in $B) {
    curl.exe -s --get "$BASE/ai/chat" --data-urlencode "msg=$q" --data-urlencode "conversationId=testB" | Out-Null
    Write-Host "  ✓ $q"
}

# ===== 最终统计 =====
Write-Host "`n===== 最终统计 =====" -ForegroundColor Cyan
curl.exe -s "$BASE/ai/stats"