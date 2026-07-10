package com.baeumpay.backend.point.dto;

import com.baeumpay.backend.point.entity.PointWallet;

public record PointResponse(
        Long userId,
        Long balance
) {

    public static PointResponse from(PointWallet wallet) {
        return new PointResponse(
                wallet.getUserId(),
                wallet.getBalance()
        );
    }
}