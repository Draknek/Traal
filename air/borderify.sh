#!/bin/bash

for size in 36 48 72 96 144
do
	offset=$(($size / 36))
	offset2=$(($size - $offset - 1))
	radius=$(($size / 12))
	input=${size}x${size}.png
	output=${size}x${size}-border.png
	echo "Converting $input"
	convert -size ${size}x${size} xc:none -fill white -draw \
		"roundrectangle $offset,$offset $offset2,$offset2 $radius,$radius" \
		$input -compose SrcIn -composite $output
done