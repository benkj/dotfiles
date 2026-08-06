function lezionipdf
     for i in *.svgz; /home/benkj/Downloads/Write/Write --exit --out $(path change-extension pdf $i) $i; end; 
end
