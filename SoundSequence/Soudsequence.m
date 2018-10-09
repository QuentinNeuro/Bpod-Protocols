SnipDuration=0.5;
Samplingrate=92000;
TimeSound=0:1/Samplingrate:SnipDuration;

sylA=chirp(TimeSound,10000,SnipDuration,18000,'quadratic');
sylB=chirp(TimeSound,10000,SnipDuration,4000,'quadratic');
sylC=chirp(TimeSound,18000,SnipDuration,5000);
sylD=SoundGenerator(Samplingrate,8000,2000,5,SnipDuration,0);
sylE=SoundGenerator(Samplingrate,15000,3000,5,SnipDuration,0);

sylDlong=SoundGenerator(Samplingrate,8000,2000,5,SnipDuration*2,0);
sylNew=chirp(-SnipDuration/2:1/Samplingrate:SnipDuration/2,2000,1,15000,'quadratic',[],'concave');

SeqNormal=[sylA sylD sylB sylC sylNew];
SeqAbsence=[sylA sylD sylB sylE];
SeqLong=[sylA sylD sylDlong sylB sylC sylE];
SeqSwap=[sylA sylD sylB sylE sylC];
SeqNew=[sylA sylD sylB sylNew sylE sylC];
SeqSilence=[sylA sylD sylB sylC*0 sylE];

Sequence=[];
for i=1:10
    Sequence=[Sequence SeqNormal];
end
Sequence=[Sequence SeqLong];
for i=1:4
    Sequence=[Sequence SeqNormal];
end
Sequence=[Sequence SeqSwap];
for i=1:8
    Sequence=[Sequence SeqNormal];
end
Sequence=[Sequence SeqSilence];
for i=1:4
    Sequence=[Sequence SeqNormal];
end
Sequence=[Sequence SeqNew];
for i=1:6
    Sequence=[Sequence SeqNormal];
end

soundsc(Sequence,Samplingrate)
spectrogram(Sequence,20000,'yaxis')
% soundsc(sylNew,Samplingrate)