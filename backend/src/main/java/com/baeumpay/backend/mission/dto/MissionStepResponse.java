package com.baeumpay.backend.mission.dto;

import com.baeumpay.backend.mission.entity.MissionStep;

import java.time.LocalDateTime;

public record MissionStepResponse(
        Long stepId,
        Long missionId,
        Integer stepOrder,
        String instructionText,
        String correctAction,
        String voiceGuideText,
        LocalDateTime createdAt
) {
    public static MissionStepResponse from(MissionStep step) {
        return new MissionStepResponse(
                step.getStepId(),
                step.getMissionId(),
                step.getStepOrder(),
                step.getInstructionText(),
                step.getCorrectAction(),
                step.getVoiceGuideText(),
                step.getCreatedAt()
        );
    }
}
