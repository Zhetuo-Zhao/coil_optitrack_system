function saveFigure(fileName, outputFolder)
    saveas(gcf,[outputFolder fileName '.png'])
    saveas(gcf,[outputFolder fileName], 'epsc')
    saveas(gcf,[outputFolder fileName '.fig'])

end