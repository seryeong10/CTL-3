package com.baeumpay.backend.toucherror.dto;

import com.baeumpay.backend.toucherror.entity.TouchErrorLog;

import java.time.LocalDateTime;

public record TouchErrorLogResponse(
        Long errorId,
        Long userId,
        Long missionId,
        Long stepId,
        String wrongAction,
        LocalDateTime createdAt
) {
    public static TouchErrorLogResponse from(TouchErrorLog log) {
        return new TouchErrorLogResponse(
                log.getErrorId(),
                log.getUserId(),
                log.getMissionId(),
                log.getStepId(),
                log.getWrongAction(),
                log.getCreatedAt()
        );
    }
}
