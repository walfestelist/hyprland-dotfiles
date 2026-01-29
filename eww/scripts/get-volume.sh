#!/bin/bash

amixer get Master | grep -Po '\[\d+%\]' | head -1 | tr -d '[]%'
