package com.baeumpay.backend.merchant.controller;

import com.baeumpay.backend.merchant.dto.MerchantCreateRequest;
import com.baeumpay.backend.merchant.dto.MerchantResponse;
import com.baeumpay.backend.merchant.service.MerchantService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/merchants")
public class MerchantController {

    private final MerchantService merchantService;

    @PostMapping
    public MerchantResponse createMerchant(
            @Valid @RequestBody MerchantCreateRequest request
    ) {

        return merchantService.createMerchant(request);
    }

    @GetMapping
    public List<MerchantResponse> getMerchants() {

        return merchantService.getMerchants();
    }

    @GetMapping("/{merchantId}")
    public MerchantResponse getMerchant(
            @PathVariable Long merchantId
    ) {

        return merchantService.getMerchant(merchantId);
    }
}