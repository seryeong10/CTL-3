package com.baeumpay.backend.point.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "point_transaction")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class PointTransaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long transactionId;

    @Column(nullable = false)
    private Long userId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PointTransactionType type;

    @Column(nullable = false)
    private Long amount;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PointSourceType sourceType;

    private Long referenceId;

    @Column(nullable = false)
    private String description;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    public PointTransaction(
            Long userId,
            PointTransactionType type,
            Long amount,
            PointSourceType sourceType,
            Long referenceId,
            String description
    ) {
        this.userId = userId;
        this.type = type;
        this.amount = amount;
        this.sourceType = sourceType;
        this.referenceId = referenceId;
        this.description = description;
        this.createdAt = LocalDateTime.now();
    }
}