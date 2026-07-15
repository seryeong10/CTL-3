package com.baeumpay.backend.guardian.dto;

import com.baeumpay.backend.guardian.entity.GuardianLink;

import java.time.LocalDateTime;

public record GuardianLinkResponse(
        Long linkId,
        Long guardianUserId,
        Long seniorUserId,
        String relation,
        LocalDateTime createdAt
) {
    public static GuardianLinkResponse from(GuardianLink link) {
        return new GuardianLinkResponse(
                link.getLinkId(),
                link.getGuardianUserId(),
                link.getSeniorUserId(),
                link.getRelation(),
                link.getCreatedAt()
        );
    }
}
