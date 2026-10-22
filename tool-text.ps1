# ============================================
# 工具调用完整测试
# 覆盖 4 个工具 × (正常 + 异常) 场景
# ============================================

$BASE = "http://localhost:8899"

# 重置统计
Write-Host "`n===== 重置统计 =====" -ForegroundColor Yellow
curl.exe -s -X POST "$BASE/ai/tool-stats/reset" | Out-Null

# ============================================
# jobQuery：2 正常 + 2 异常
# ============================================
Write-Host "`n===== jobQuery =====" -ForegroundColor Cyan

$jobNormal = @(
    "Python工程师岗位要求是什么",           # 正常（job 表里有）
    "Java工程师需要什么技能"               # 正常
)
foreach ($q in $jobNormal) {
    Write-Host "  [正常] $q" -NoNewline
    curl.exe -s --get "$BASE/ai/chat" --data-urlencode "msg=$q" --data-urlencode "conversationId=t1" | Out-Null
    Write-Host " ✓" -ForegroundColor Green
    Start-Sleep -Milliseconds 800
}

$jobAbnormal = @(
    "量子物理工程师岗位要求是什么",          # 业务失败（不存在，工具正常执行）
    "查一下岗位要求"                       # 参数缺失（模型可能反问，不一定调）
)
foreach ($q in $jobAbnormal) {
    Write-Host "  [异常] $q" -NoNewline
    curl.exe -s --get "$BASE/ai/chat" --data-urlencode "msg=$q" --data-urlencode "conversationId=t1" | Out-Null
    Write-Host " ✓" -ForegroundColor Yellow
    Start-Sleep -Milliseconds 800
}

# ============================================
# applicationQuery：2 正常 + 1 异常
# ============================================
Write-Host "`n===== applicationQuery =====" -ForegroundColor Cyan

$appNormal = @(
    "张三投递了哪些岗位",                   # 正常（现在有投递记录了）
    "张三的投递状态是什么"                  # 正常
)
foreach ($q in $appNormal) {
    Write-Host "  [正常] $q" -NoNewline
    curl.exe -s --get "$BASE/ai/chat" --data-urlencode "msg=$q" --data-urlencode "conversationId=t1" | Out-Null
    Write-Host " ✓" -ForegroundColor Green
    Start-Sleep -Milliseconds 800
}

$appAbnormal = @(
    "王五投递了哪些岗位"                    # 业务失败（王五没投递）
)
foreach ($q in $appAbnormal) {
    Write-Host "  [异常] $q" -NoNewline
    curl.exe -s --get "$BASE/ai/chat" --data-urlencode "msg=$q" --data-urlencode "conversationId=t1" | Out-Null
    Write-Host " ✓" -ForegroundColor Yellow
    Start-Sleep -Milliseconds 800
}

# ============================================
# screenCandidate：2 正常 + 1 异常
# ============================================
Write-Host "`n===== screenCandidate =====" -ForegroundColor Cyan

$screenNormal = @(
    "筛选会Rust的候选人",                   # 正常（李四会 Rust）
    "筛选会Python的候选人"                  # 正常（王五会 Python）
)
foreach ($q in $screenNormal) {
    Write-Host "  [正常] $q" -NoNewline
    curl.exe -s --get "$BASE/ai/chat" --data-urlencode "msg=$q" --data-urlencode "conversationId=t1" | Out-Null
    Write-Host " ✓" -ForegroundColor Green
    Start-Sleep -Milliseconds 800
}

$screenAbnormal = @(
    "筛选会量子计算的候选人"                 # 业务失败（没人会）
)
foreach ($q in $screenAbnormal) {
    Write-Host "  [异常] $q" -NoNewline
    curl.exe -s --get "$BASE/ai/chat" --data-urlencode "msg=$q" --data-urlencode "conversationId=t1" | Out-Null
    Write-Host " ✓" -ForegroundColor Yellow
    Start-Sleep -Milliseconds 800
}

# ============================================
# sendInterview：2 正常 + 1 异常
# ★ 关键：正常调用必须带齐 候选人 + 岗位 + 时间
# ============================================
Write-Host "`n===== sendInterview =====" -ForegroundColor Cyan

$interviewNormal = @(
    "请安排张三在2026-10-30T14:00:00面试Python工程师岗位",     # 正常（带齐 3 个参数）
    "帮张三约2026-11-01T10:00:00面试Java工程师"                # 正常（另一个岗位）
)
foreach ($q in $interviewNormal) {
    Write-Host "  [正常] $q" -NoNewline
    curl.exe -s --get "$BASE/ai/chat" --data-urlencode "msg=$q" --data-urlencode "conversationId=t1" | Out-Null
    Write-Host " ✓" -ForegroundColor Green
    Start-Sleep -Milliseconds 800
}

$interviewAbnormal = @(
    "帮我安排一场面试"                       # 参数缺失（模型可能反问，不调工具）
)
foreach ($q in $interviewAbnormal) {
    Write-Host "  [异常] $q" -NoNewline
    curl.exe -s --get "$BASE/ai/chat" --data-urlencode "msg=$q" --data-urlencode "conversationId=t1" | Out-Null
    Write-Host " ✓" -ForegroundColor Yellow
    Start-Sleep -Milliseconds 800
}

# ============================================
# 最终统计
# ============================================
Write-Host "`n===== 工具调用统计 =====" -ForegroundColor Cyan
curl.exe -s "$BASE/ai/tool-stats"
Write-Host ""