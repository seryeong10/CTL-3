package com.baeumpay.backend.merchant.service;

import com.baeumpay.backend.merchant.dto.MerchantCreateRequest;
import com.baeumpay.backend.merchant.dto.MerchantResponse;
import com.baeumpay.backend.merchant.entity.Merchant;
import com.baeumpay.backend.merchant.repository.MerchantRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MerchantService {

    private final MerchantRepository merchantRepository;

    @Transactional
    public MerchantResponse createMerchant(
            MerchantCreateRequest request
    ) {

        Merchant merchant = new Merchant(
                request.name(),
                request.address(),
                request.latitude(),
                request.longitude(),
                request.phoneNumber(),
                request.businessHours()
        );

        Merchant savedMerchant =
                merchantRepository.save(merchant);

        return MerchantResponse.from(savedMerchant);
    }

    public List<MerchantResponse> getMerchants() {

        return merchantRepository
                .findByActiveTrueOrderByNameAsc()
                .stream()
                .map(MerchantResponse::from)
                .toList();
    }

    public MerchantResponse getMerchant(
            Long merchantId
    ) {

        Merchant merchant =
                merchantRepository.findById(merchantId)
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "가맹점을 찾을 수 없습니다."
                                )
                        );

        return MerchantResponse.from(merchant);
    }
}