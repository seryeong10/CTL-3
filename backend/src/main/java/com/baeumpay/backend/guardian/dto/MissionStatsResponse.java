package com.baeumpay.backend.guardian.dto;

public record MissionStatsResponse(
        long totalAttempts,
        long successCount,
        double successRate
) {}
