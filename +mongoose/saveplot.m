function saveplot(han,direct,name,type)
%% saveplot
%
%  This functions generalizes the saving of figures for maintaining
%  consistantly readable figures for documents.
%
%% Script
%
top_dir = pwd;

cd(direct)

if type == 1
    
    set(gcf, 'PaperPosition', [0 0 4 2]);
    set(gcf, 'PaperSize', [4 2]);
    saveas(han,name,'png')
    
elseif type == 2
    
    set(gcf, 'PaperPosition', [0 0 6 3]);
    set(gcf, 'PaperSize', [6 3]);
    saveas(han,name,'epsc')
elseif type == 3
    
    set(gcf, 'PaperPosition', [0 0 4 2]);
    set(gcf, 'PaperSize', [4 2]);
    saveas(han,name,'png')
    
elseif type == 4
    
    set(gcf, 'PaperPosition', [0 0 5 3]);
    set(gcf, 'PaperSize', [5 3]);
    saveas(han,name,'epsc')
    
elseif type == 5
    
    set(gcf, 'PaperPosition', [0 0 5 6.5]);
    set(gcf, 'PaperSize', [5 6.5]);
    saveas(han,name,'epsc')
end

cd(top_dir)