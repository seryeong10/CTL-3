package com.baeumpay.backend.merchant.repository;

import com.baeumpay.backend.merchant.entity.Merchant;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MerchantRepository
        extends JpaRepository<Merchant, Long> {

    List<Merchant> findByActiveTrueOrderByNameAsc();
}