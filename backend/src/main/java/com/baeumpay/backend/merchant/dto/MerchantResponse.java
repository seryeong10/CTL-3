package com.baeumpay.backend.merchant.dto;

import com.baeumpay.backend.merchant.entity.Merchant;

public record MerchantResponse(
        Long merchantId,
        String name,
        String address,
        Double latitude,
        Double longitude,
        String phoneNumber,
        String businessHours,
        Boolean active
) {

    public static MerchantResponse from(
            Merchant merchant
    ) {

        return new MerchantResponse(
                merchant.getMerchantId(),
                merchant.getName(),
                merchant.getAddress(),
                merchant.getLatitude(),
                merchant.getLongitude(),
                merchant.getPhoneNumber(),
                merchant.getBusinessHours(),
                merchant.getActive()
        );
    }
}