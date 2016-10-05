#!/bin/sh

export PROJECT_DIR=/Users/brennan/Documents/GitHub/brennanMKE/OverTheAir
export PROJECT_NAME=OverTheAir

export OTA_HOST=https://ota-demo.s3.amazonaws.com
export OTA_NAME=OverTheAir
export OTA_FULL_NAME=OverTheAir
export OTA_APP_IDENTIFIER=com.smallsharptools.OverTheAir
export OTA_BACKGROUND_COLOR=#ddd
export OTA_FOREGROUND_COLOR=#fff

/usr/bin/swift prepare_ota.swift
