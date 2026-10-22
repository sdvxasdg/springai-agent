package com.atguigo.springaiproject_1.metrics;

import org.springframework.stereotype.Component;
import java.util.concurrent.atomic.AtomicLong;

@Component
public class RagMetrics {

    private final AtomicLong totalQueries = new AtomicLong();   // 总检索次数
    private final AtomicLong hitQueries = new AtomicLong();     // 命中次数
    private final AtomicLong shortCircuit = new AtomicLong();   // 空检索短路次数

    public void recordQuery(boolean hit) {
        totalQueries.incrementAndGet();
        if (hit) {
            hitQueries.incrementAndGet();
        } else {
            shortCircuit.incrementAndGet();
        }
    }

    public long getTotal() { return totalQueries.get(); }
    public long getHit() { return hitQueries.get(); }
    public long getShortCircuit() { return shortCircuit.get(); }

    public double getHitRate() {
        long total = totalQueries.get();
        return total == 0 ? 0.0 : (double) hitQueries.get() / total;
    }
}