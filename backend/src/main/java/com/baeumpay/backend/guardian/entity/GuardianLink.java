package com.baeumpay.backend.guardian.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "guardian_link",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_guardian_senior",
                        columnNames = {"guardian_user_id", "senior_user_id"}
                )
        }
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class GuardianLink {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long linkId;

    @Column(nullable = false)
    private Long guardianUserId;

    @Column(nullable = false)
    private Long seniorUserId;

    @Column(length = 50)
    private String relation;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    public GuardianLink(Long guardianUserId, Long seniorUserId, String relation) {
        this.guardianUserId = guardianUserId;
        this.seniorUserId = seniorUserId;
        this.relation = relation;
        this.createdAt = LocalDateTime.now();
    }
}
