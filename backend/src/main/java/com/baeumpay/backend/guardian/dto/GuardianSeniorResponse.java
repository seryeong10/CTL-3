package com.baeumpay.backend.guardian.dto;

import java.time.LocalDateTime;

public record GuardianSeniorResponse(
        Long linkId,
        String relation,
        LocalDateTime linkedAt,
        Long seniorId,
        String name,
        String phone,
        Integer birthYear,
        Long walletBalance,
        MissionStatsResponse missionStats
) {}
