package com.baeumpay.backend.point.repository;

import com.baeumpay.backend.point.entity.PointWallet;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface PointWalletRepository
        extends JpaRepository<PointWallet, Long> {

    Optional<PointWallet> findByUserId(Long userId);
}