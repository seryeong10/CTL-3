package com.baeumpay.backend.mission.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "mission")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Mission {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long missionId;

    @Column(nullable = false, length = 100)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(length = 50)
    private String category;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private MissionDifficulty difficulty;

    @Column(nullable = false)
    private Long rewardPoint;

    @Column(nullable = false)
    private boolean active;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    public Mission(String title, String description, String category,
                   MissionDifficulty difficulty, Long rewardPoint) {
        this.title = title;
        this.description = description;
        this.category = category;
        this.difficulty = difficulty;
        this.rewardPoint = rewardPoint;
        this.active = true;
        this.createdAt = LocalDateTime.now();
    }

    public void deactivate() {
        this.active = false;
    }
}
