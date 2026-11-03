function [] = PRPX_sendTrigger(Trig)
% function to send any trigger
%   and stops all schedules

if nargin <1, return; end

Datapixx('StopAllSchedules');
Datapixx('RegWrRd');
WaitSecs(1);
Datapixx('SetDoutValues', 0);
Datapixx('RegWrRd');
WaitSecs(0.01);
Datapixx('SetDoutValues', Trig); % send trigger
Datapixx('RegWrRd');
WaitSecs(0.01);
Datapixx('SetDoutValues', 0);
Datapixx('RegWrRd');

end

