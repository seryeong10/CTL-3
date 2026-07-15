package com.baeumpay.backend.mission.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "mission_step")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class MissionStep {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long stepId;

    @Column(nullable = false)
    private Long missionId;

    @Column(nullable = false)
    private Integer stepOrder;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String instructionText;

    @Column(length = 100)
    private String correctAction;

    @Column(columnDefinition = "TEXT")
    private String voiceGuideText;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    public MissionStep(Long missionId, Integer stepOrder, String instructionText,
                       String correctAction, String voiceGuideText) {
        this.missionId = missionId;
        this.stepOrder = stepOrder;
        this.instructionText = instructionText;
        this.correctAction = correctAction;
        this.voiceGuideText = voiceGuideText;
        this.createdAt = LocalDateTime.now();
    }
}
