SIZE=size(data);
garbage=zeros(SIZE(1,1),1);
for i=1:SIZE(1,2)
    
    garbage=data(:,i)+garbage;
end
ID=ones(SIZE(1,1),1);
for i=1:SIZE(1,2)
    ID(i)=ID(i)-isnan(garbage(i));
end
id=data(:,1);

l=0;
data_image=zeros(SIZE(1,1),SIZE(1,2)-1);
for i=1:SIZE(1,1);
    if(isnan(garbage(i)))
    else
        l=l+1;
        data_image(l,:)=data(i,2:SIZE(1,2));
    end
end

%% Gaussian Mixture Model
[coef,score,latent,tsquared,explained]=pca(data_image);
data_image=score;
MAX=max(data_image);
MIN=min(data_image);
siz=size(data_image);
for i=1:siz(1,1)
    data_image(i,:)=(data_image(i,:)-MIN)./(MAX-MIN);
end
data_image=data_image(:,1:80);
siz=size(data_image);
k=2;
[idx,C]=kmeans(data_image,k);
n=siz(1,1);

%initiallization
wold=zeros(n,k);
mew=zeros(k,siz(1,2));
phi=zeros(1,k);
co_variance=cell(1,k);
a1=eye(k,siz(1,2));
for j=1:k
    %mew(j,:)=C(j,:);       %initiallizing means using Kmeans
    
    mew(j,:)=a1(j);       % initializing means randomly      
    phi(j)=1/3;            %initializing probability
    co_variance{j}=eye(siz(1,2)); %initializing variance
end

% prior
wnew=ones(n,k)*(1/k);



% M step
iter=0;
while(mean(mean(abs(wold-wnew)))>.009)
    iter=iter+1;
    wold=wnew;
    %E step
    for i=1:n
        den=0;
        for j=1:k
            probability=(1/(((2*pi)^(siz(1,2)))*sqrt(det(co_variance{j}))))*(exp(-0.5*(data_image(i,:)-mew(j,:))*inv(co_variance{j})*(data_image(i,:)-mew(j,:))'));;
            den=den+probability;
            wnew(i,j)=probability;
        end
        for j=1:k
            wnew(i,j)=wnew(i,j)/den;
        end
    end
    % M step
    for i=1:k
        phi(i)=mean(wnew(:,k));
    end

    for j=1:k
        s=zeros(1,siz(1,2));
        for i=1:n
           s=s+wnew(i,j)*data_image(i,:);
        end
        mew(j,:)=s/(n*phi(j));
    end

    for j=1:k
        v=zeros(siz(1,2));
        for i=1:n
            v=v+wnew(i,j)*(data_image(i,:)-mew(j,:))'*(data_image(i,:)-mew(j,:));
        end
        co_variance{j}=v/(n*phi(j));
    end
end
wnew;

% analyze=[];
% for i=1:siz(1,1)
%    index=find(wnew(i,:)>.116);
%    l=size(index);
%    if(l(1,2)>1)
%        analyze(end+1)=i;
%    end
% end
% idx=zeros(siz(1,1),1);
% for i=1:siz(1,1)
%     index=find(wnew(i,:)==max(wnew(i,:)));
%     idx(i)=index(1);
% end
% class=cell(10,1);
% for i=1:siz(1,1)
%     class{idx(i)}(end+1)=i;
% end
% Label=zeros(siz(1,1),1);
% for i=1:10
%     n1=size(class{i});
%     C=class{i};
%     label=zeros(1,10);
%     for j=1:n1(1,2)
%         label(data_labels(C(j))+1)=label(data_labels(C(j))+1)+1;
%     end
%     index=find(label==max(label));
%     l1(i)=index(1)-1;
%     for j=1:n1(1,2)
%         Label(C(j))=Label(C(j))+l1(i);
%     end    
% end
% e=data_labels-Label;
% accuracy=1-nnz(e)/siz(1,1);
% hold
% plot(data_labels,'*r');
% plot(Label,'.','markers',15);
% set(gca,'fontsize',24);
% xlabel('Data points')
% ylabel('Labels')
% legend('Actual','Predicted');
