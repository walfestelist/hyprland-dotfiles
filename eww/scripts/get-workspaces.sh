#!/bin/bash
hyprctl activeworkspace -j | jq '.id'
