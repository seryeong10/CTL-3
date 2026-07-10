package com.baeumpay.backend.point.dto;

public record PointRewardResponse(
        Long userId,
        Long earnedPoint,
        Long balance,
        long todayRewardCount,
        boolean rewardGranted,
        String message
) {
}