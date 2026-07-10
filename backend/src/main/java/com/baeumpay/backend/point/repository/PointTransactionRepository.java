package com.baeumpay.backend.point.repository;

import com.baeumpay.backend.point.entity.PointSourceType;
import com.baeumpay.backend.point.entity.PointTransaction;
import com.baeumpay.backend.point.entity.PointTransactionType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface PointTransactionRepository
        extends JpaRepository<PointTransaction, Long> {

    long countByUserIdAndTypeAndSourceTypeAndCreatedAtBetween(
            Long userId,
            PointTransactionType type,
            PointSourceType sourceType,
            LocalDateTime start,
            LocalDateTime end
    );

    List<PointTransaction> findByUserIdOrderByCreatedAtDesc(
            Long userId
    );
}