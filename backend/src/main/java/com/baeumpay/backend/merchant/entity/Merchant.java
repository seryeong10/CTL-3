package com.baeumpay.backend.merchant.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "merchant")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Merchant {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long merchantId;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String address;

    @Column(nullable = false)
    private Double latitude;

    @Column(nullable = false)
    private Double longitude;

    @Column(nullable = false)
    private String phoneNumber;

    @Column(nullable = false)
    private String businessHours;

    @Column(nullable = false)
    private Boolean active;

    public Merchant(
            String name,
            String address,
            Double latitude,
            Double longitude,
            String phoneNumber,
            String businessHours
    ) {
        this.name = name;
        this.address = address;
        this.latitude = latitude;
        this.longitude = longitude;
        this.phoneNumber = phoneNumber;
        this.businessHours = businessHours;
        this.active = true;
    }
}