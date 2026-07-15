package com.baeumpay.backend.guardian.dto;

import java.time.LocalDateTime;

public record SeniorGuardianResponse(
        Long linkId,
        String relation,
        Long guardianId,
        String name,
        String phone,
        LocalDateTime linkedAt
) {}
