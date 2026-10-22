package com.atguigo.springaiproject_1.tools;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;
/**
 * 工具调用日志的统一封装。
 * 4 个 Function 都用它打印，保证格式一致、方便 grep。
 */
public final class ToolLogger {

//    private static final Logger log = LoggerFactory.getLogger("TOOL");
//
//    private ToolLogger() {}
//
//    /** 工具开始调用 */
//    public static void onEnter(String toolName, Object request) {
//        log.info(">>> [TOOL] {} 调用开始, 参数={}", toolName, request);
//    }
//
//    /** 参数校验失败 */
//    public static void onInvalidArgs(String toolName, String reason) {
//        log.warn(">>> [TOOL] {} 参数不合法: {}", toolName, reason);
//    }
//
//    /** 工具调用成功 */
//    public static void onSuccess(String toolName, Object response, long costMs) {
//        log.info(">>> [TOOL] {} 调用成功, 耗时={}ms, 返回={}", toolName, costMs, response);
//    }
//
//    /** 业务失败（比如"未找到"）*/
//    public static void onBusinessFail(String toolName, String reason) {
//        log.info(">>> [TOOL] {} 业务失败: {}", toolName, reason);
//    }
//
//    /** 系统异常 */
//    public static void onError(String toolName, Throwable e) {
//        log.error(">>> [TOOL] {} 执行异常", toolName, e);
//    }
private static final Logger log = LoggerFactory.getLogger("TOOL");

    // ★ 新增：统计数据
    private static final Map<String, AtomicLong> totalMap = new ConcurrentHashMap<>();
    private static final Map<String, AtomicLong> successMap = new ConcurrentHashMap<>();
    private static final Map<String, AtomicLong> failMap = new ConcurrentHashMap<>();

    private ToolLogger() {}

    public static void onEnter(String toolName, Object request) {
        log.info(">>> [TOOL] {} 调用开始, 参数={}", toolName, request);
    }

    public static void onInvaliArgs(String toolName, String reason) {
        log.warn(">>> [TOOL] {} 参数不合法: {}", toolName, reason);
        count(toolName, false);         // ★ 参数错误算失败
    }

    public static void onSuccess(String toolName, Object response, long costMs) {
        log.info(">>> [TOOL] {} 调用成功, 耗时={}ms, 返回={}", toolName, costMs, response);
        count(toolName, true);          // ★ 成功
    }

    public static void onBusinessFail(String toolName, String reason) {
        log.info(">>> [TOOL] {} 业务失败: {}", toolName, reason);
        //   不调 count，由外层 onSuccess 统一计数
//        count(toolName, false);         // ★ 业务失败算失败
    }

    public static void onError(String toolName, Throwable e) {
        log.error(">>> [TOOL] {} 执行异常", toolName, e);
        count(toolName, false);         // ★ 系统异常算失败
    }

    // ★ 计数
    private static void count(String toolName, boolean success) {
        totalMap.computeIfAbsent(toolName, k -> new AtomicLong()).incrementAndGet();
        if (success) {
            successMap.computeIfAbsent(toolName, k -> new AtomicLong()).incrementAndGet();
        } else {
            failMap.computeIfAbsent(toolName, k -> new AtomicLong()).incrementAndGet();
        }
    }

    // ★ 对外暴露统计
    public static Map<String, Map<String, Object>> getStats() {
        Map<String, Map<String, Object>> result = new ConcurrentHashMap<>();
        totalMap.forEach((tool, total) -> {
            long t = total.get();
            long s = successMap.getOrDefault(tool, new AtomicLong()).get();
            long f = failMap.getOrDefault(tool, new AtomicLong()).get();
            Map<String, Object> stat = new ConcurrentHashMap<>();
            stat.put("total", t);
            stat.put("success", s);
            stat.put("fail", f);
            stat.put("successRate", t == 0 ? "0%" : String.format("%.2f%%", (double) s / t * 100));
            result.put(tool, stat);
        });
        return result;
    }

    // ★ 重置
    public static void reset() {
        totalMap.clear();
        successMap.clear();
        failMap.clear();
    }
}