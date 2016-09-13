sca
clear settingsStruct
settingsStruct.display.destinationFactorNew=GL_ONE_MINUS_SRC_ALPHA;
settingsStruct.display.sourceFactorNew=GL_SRC_ALPHA;

p=pldaps(@plain, 'test', settingsStruct);

p=openScreen(p);
p.trial.display.switchOverlayCLUTs=0;
p.trial.display.useOverlay=2;
p=pds.datapixx.init(p);


%% test pixel noise


n=stimuli.pixelNoise(p.trial.display.ptr, 'type', 'sparse', 'sigma', .05);
n.setup

iter=10;
while iter > 0
    
    n.update
    n.draw
    Screen('Flip', p.trial.display.ptr, 0);
    pause(.1)
    iter=iter-1;
end

%% test gaussian noise

n=stimuli.gaussianNoise(p.trial.display.ptr, 'contrast', .25, 'sc', 20, 'count', 200);
n.setup
Screen('Flip', p.trial.display.ptr, 0);
%%
t0=GetSecs;
n.update
t1=GetSecs-t0;
fprintf('update took %0.5f ms\n', t1*1e3)
t0=GetSecs;
n.draw
t1=GetSecs-t0;
fprintf('draw took %0.5f ms\n', t1*1e3)
Screen('Flip', p.trial.display.ptr, 0);

im=n.image;
img=Screen('GetImage', p.trial.display.ptr, [0 0 1920 1080]);
figure(1); clf
subplot(131); imagesc(mean(img,3)); colorbar; title('PTB image'); subplot(132); imagesc(im); colorbar; title('Matlab Evaluated Gaussians'); subplot(133); imagesc(mean(img,3)-(im)); colorbar; title('Difference')

figure(2); clf
imdiff=mean(img,3)-(im);
[i,j]=find(imdiff==max(imdiff(:)), 1);
plot(img(i,:,1)); hold on; plot(im(i,:))



%%
tex = CreateProceduralGaussBlob(p.trial.display.ptr, 150, 150, [0 0 0 0], 1, -.5);
%             n.tex2 = CreateProceduralGaussBlob(n.ptr, 150, 150, [1 1 1 0], 0, .5);
            
Screen('DrawTexture', p.trial.display.ptr, tex, [], [400 400 800 800], [], [], [], 0, [], kPsychDontDoRotation, [-.5, 10, 1, 0]);
Screen('DrawTexture', p.trial.display.ptr, tex, [], [400 400 800 800], [], [], [], 0, [], kPsychDontDoRotation, [.5, 10, 1, 0]);

Screen('Flip', p.trial.display.ptr, 0);

Screen('Close', tex)
%%

d=stimuli.dots(p.trial.display.ptr, ...
    'size', 5, ...
    'speed', 5, ... 
    'direction', 90, ...
    'numDots', 30, ...
    'coherence', .5, ...
    'mode', 1, ...
    'dist', 1, ...
    'bandwdth', 50, ...
    'lifetime', 5, ...
    'maxRadius', 100, ...
    'position', p.trial.display.ctr(1:2));

f=stimuli.fixation(p.trial.display.overlayptr, ...
    'centreSize', 10, ...
    'surroundSize', 20, ...
    'position', p.trial.display.ctr(1:2), ...
    'fixType', 2, ...
    'winType', 2, ...
    'centreColour', p.trial.display.clut.black, ...
    'surroundColour', p.trial.display.clut.white, ...
    'winColour', 2);

t=stimuli.targetAnnulus(p.trial.display.overlayptr, ...
    'radius', 10, ...
    'size', 300, ...
    'position', p.trial.display.ctr(1:2), ...
    'thetaSpan', [0 45], ...
    'colour', p.trial.display.clut.window);

d.beforeTrial
t.beforeTrial





%%
f.winRadius=f.winRadius+randn;
d.draw;
t.draw;
f.drawFixation
d.update;
Screen('Flip', p.trial.display.ptr, 0);
Screen('FillRect', p.trial.display.overlayptr, 0);
