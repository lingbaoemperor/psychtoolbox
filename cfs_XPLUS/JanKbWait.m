function JanKbWait(ignore_subject);


if (ignore_subject) 
		return
end


%process keys, just because
%[keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
%wait for a mouse button
%[clicks,x,y,whichButton] = GetClicks();

KbWait([],2);
