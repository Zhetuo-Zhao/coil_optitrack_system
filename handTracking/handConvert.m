function out=handConvert(in)

    out=in;
    
    out.axis(2)=-out.axis(2);
    out.axis(3)=-out.axis(3);
    
    out.position(1)=-out.position(1);
end