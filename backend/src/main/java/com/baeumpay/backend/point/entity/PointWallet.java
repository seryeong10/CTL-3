package com.baeumpay.backend.point.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "point_wallet")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class PointWallet {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long walletId;

    @Column(nullable = false, unique = true)
    private Long userId;

    @Column(nullable = false)
    private Long balance;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    public PointWallet(Long userId) {
        this.userId = userId;
        this.balance = 0L;
        this.updatedAt = LocalDateTime.now();
    }

    public void earn(Long amount) {

        if (amount == null || amount <= 0) {
            throw new IllegalArgumentException(
                    "적립 포인트는 0보다 커야 합니다."
            );
        }

        this.balance += amount;
        this.updatedAt = LocalDateTime.now();
    }

    public void use(Long amount) {

        if (amount == null || amount <= 0) {
            throw new IllegalArgumentException(
                    "사용 포인트는 0보다 커야 합니다."
            );
        }

        if (this.balance < amount) {
            throw new IllegalArgumentException(
                    "보유 포인트가 부족합니다."
            );
        }

        this.balance -= amount;
        this.updatedAt = LocalDateTime.now();
    }
}