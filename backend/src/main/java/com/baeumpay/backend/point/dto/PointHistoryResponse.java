package com.baeumpay.backend.point.dto;

import com.baeumpay.backend.point.entity.PointSourceType;
import com.baeumpay.backend.point.entity.PointTransaction;
import com.baeumpay.backend.point.entity.PointTransactionType;

import java.time.LocalDateTime;

public record PointHistoryResponse(
        Long transactionId,
        PointTransactionType type,
        Long amount,
        PointSourceType sourceType,
        Long referenceId,
        String description,
        LocalDateTime createdAt
) {

    public static PointHistoryResponse from(
            PointTransaction transaction
    ) {

        return new PointHistoryResponse(
                transaction.getTransactionId(),
                transaction.getType(),
                transaction.getAmount(),
                transaction.getSourceType(),
                transaction.getReferenceId(),
                transaction.getDescription(),
                transaction.getCreatedAt()
        );
    }
}