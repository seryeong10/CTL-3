package com.baeumpay.backend.inquiry.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "inquiry")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Inquiry {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long inquiryId;

    @Column(nullable = false)
    private Long userId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private InquiryType type;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private InquiryStatus status;

    @Column(columnDefinition = "TEXT")
    private String answer;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    private LocalDateTime answeredAt;

    public Inquiry(
            Long userId,
            InquiryType type,
            String title,
            String content
    ) {
        this.userId = userId;
        this.type = type;
        this.title = title;
        this.content = content;
        this.status = InquiryStatus.RECEIVED;
        this.createdAt = LocalDateTime.now();
    }

    public void answer(
            String answer
    ) {

        if (answer == null || answer.isBlank()) {
            throw new IllegalArgumentException(
                    "답변 내용을 입력해야 합니다."
            );
        }

        this.answer = answer;
        this.status = InquiryStatus.ANSWERED;
        this.answeredAt = LocalDateTime.now();
    }
}