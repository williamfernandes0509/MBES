function [ dm, am, at, rsd, csd ] = SER( nv, ARD, DPR, dp, chr, ping, yFit )
%SER Summary of this function goes here
% Detects spikes, Eliminate & Replaces with mean value from its neighbours.
% It also stabilizes extreme outerbeam depth fluctuaions.
% Define Var explanation goes here
%  bp=zeros(nv,1);
%  bm=size(bp);
%  cd=size(bp);
%  Ht=size(bp);
 clear str0 str1 str2
%% Spike search
 str0=[' ' chr 'Beams-Ping-' '',num2str(ping) '_RCS'];
 str1=[' ' chr 'Angle-Ping-' '',num2str(ping) '_RCS'];
 str2=[' ' chr 'Beams-Ping-' '',num2str(ping) '_FinalRC'];
 h=mean(ARD);
 thr=25;
 n=h-thr;
 x=h+thr;
 m=0;
 for i=1:nv
     if i < 56
        bp(i,1)=-(9000-DPR(i,1));
     else
        bp(i,1)=9000-DPR(i,1);
     end
     bm(i,1)=i;
     if ARD(i,1) > n && ARD(i,1) < x
         cd(i,1)=ARD(i,1);
     else
         m=m+1;
         sp(m,1)=ARD(i,1);bn(m,1)=bm(i,1);ba(m,1)=bp(i,1);
         if i > 2
            cd(i,1)=(ARD(i-2,1)+ARD(i-1,1))/2;
         else
            cd(i,1)=h;
         end
      end     
 end
 for i=1:nv
     if i+2 < nv
         if i < 30 
             Ht(i,1)=(cd(i,1)+cd(i+1,1)+cd(i+2,1))/3;
         else
             Ht(i,1)=cd(i,1);
         end
         cd(i,1)=Ht(i,1);
     end
 end
 for i=nv:-1:90
     if i > 90
         Ht(i,1)=(cd(i,1)+cd(i-1,1)+cd(i-2,1))/3;
     else
         Ht(i,1)=cd(i,1);
     end
%      disp(['i: ',num2str(i),' cd: ',num2str(cd(i,1)),' Ht: ',num2str(Ht(i,1))])
     cd(i,1)=Ht(i,1);
 end
 rsd=std(dp);
 cm=mean(cd);
 for i=1:nv
     if cd(i,1) > n && cd(i,1) < x
          at(i,1)=cd(i,1);
     else
         if i < nv && i > 2
              at(i,1)=round((cd(i-1,1)+cd(i-2,1))/2);
         else
              at(i,1)=cm;
         end
     end
 end
 csd=std(at);
 am=mean(at);
 dm=mean(dp);
 for i=1:nv
     el(i,1)=at(i,1)*-1;
 end
 for i=1:nv
     mb(i,1)=el(i,1)+yFit(i,1);
 end
 for i=1:nv
     at(i,1)=mb(i,1)*-1;
 end
% if ping < 400
% h0=figure;plot(bm(1:nv,1),(dp(1:nv,1)*-1/100),'k:','LineWidth',2,'DisplayName','Raw');grid on;hold on;
% plot(bm(1:nv,1),ARD(1:nv,1)*-1/100,'k','LineWidth',2,'DisplayName','OCorr');hold on;
% if m > 0
%     plot(bn,(sp*-1/100),'bo','MarkerEdgeColor','b','MarkerFaceColor','b','MarkerSize',8,'DisplayName','Spike'); %hold on;
% end
% % plot(bm(1:nv,1),cd(1:nv,1)/100,'g','LineWidth',1);hold on;
% % plot(bm(1:nv,1),(at(1:nv,1)*-1/100),'k','LineWidth',1,'DisplayName','Final Corrected');axis tight;
% xlabel('Beam number','FontWeight','demi','FontSize',14,'FontName','Cambria');ylabel('Depth (m)','FontWeight','demi','FontSize',14,'FontName','Cambria');legend('show');
% saveas(h0,str0,'fig');close
% % %Angle
% h1=figure;plot(bp(1:nv,1)/100,(dp(1:nv,1)*-1/100),'r','LineWidth',1,'DisplayName','Raw');grid on;hold on;
% plot(bp(1:nv,1)/100,(ARD(1:nv,1)*-1/100),'k','LineWidth',1,'DisplayName','OCorr');axis tight;hold on;
% if m > 0
%     plot(ba/100,(sp*-1/100),'bo','MarkerEdgeColor','b','MarkerFaceColor','b','MarkerSize',6,'DisplayName','Spike'); %hold on;
% end
% % plot(bp(1:nv,1)/100,cd(1:nv,1)/100,'g','LineWidth',1);hold on;
% % plot(bp(1:nv,1)/100,alt(1:nv,1)/100,'r','LineWidth',1);
% xlb=['Beam Angle (' char(176) ')'];
% xlabel(xlb,'FontWeight','demi','FontSize',14,'FontName','Cambria');ylabel('Depth (m)','FontWeight','demi','FontSize',14,'FontName','Cambria');legend('show');
% saveas(h1,str1,'fig');close
% % 
% h2=figure;plot(bm(1:nv,1),(dp(1:nv,1)*-1/100),'k:','LineWidth',2,'DisplayName','Raw profile');axis tight;hold on;
% plot(bm(1:nv,1),(at(1:nv,1)*-1/100),'k','LineWidth',2,'DisplayName','Corrected profile');grid on;
% xlabel('Beam number','FontWeight','demi','FontSize',14,'FontName','Cambria');ylabel('Depth (m)','FontWeight','demi','FontSize',14,'FontName','Cambria');legend('show');
% 
% 
% saveas(h2,str2,'fig');
% % % pause(0.005)
% close 
% end
