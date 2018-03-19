



for k=1:200

    CardinalMask = create_normal_mask(720,900,4000);
    
    subplot(2,2,1)
    imagesc(CardinalMask); axis image; drawnow;
    
    ObliqueMask = imrotate(CardinalMask,45,'nearest','crop');

    subplot(2,2,2);
    imagesc(ObliqueMask); axis image; drawnow;
    
    
    CardinalMask = CardinalMask(225:450+225,180:360+180,:);
    ObliqueMask = ObliqueMask(225:450+225,180:360+180,:);
    
    subplot(2,2,3)
    imagesc(CardinalMask); axis image;
    subplot(2,2,4)
    imagesc(ObliqueMask); axis image;
    
    imwrite(CardinalMask,sprintf('Cardinal_%03d.png',k),'PNG');
    imwrite(ObliqueMask,sprintf('Oblique_%03d.png',k),'PNG');
    
end
