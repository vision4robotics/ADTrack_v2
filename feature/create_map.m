function map = create_map(I,target_sz,ratio)
w=size(I,2);
h=size(I,1);
hs=round(0.5*h-0.5*ratio*target_sz(1)):round(0.5*h+0.5*ratio*target_sz(1));
ws=round(0.5*w-0.5*ratio*target_sz(2)):round(0.5*w+0.5*ratio*target_sz(2));
center_region=I(hs,ws);
target_region=zeros(size(I));
target_region(round((h-target_sz(1))/2):round((h+target_sz(1))/2),round((w-target_sz(2))/2):round((w+target_sz(2))/2))=1;
me=mean(center_region(:));
sig=std(center_region(:),0);
map=zeros(size(I));
map(I>(me-sig)&I<(me+sig))=1;
map=map.*target_region;
end