function sampdata = get_data(inputfile, bnet)
fprintf('Getting data ...\n');
data = load(inputfile);
i_user = 1;
i_correct = 2;
i_opp = 3;

% get all unique user id
users = unique(data(:,i_user)); 

N = size(bnet.dnodes*2,2);

num_samples = size(users,1);
sampdata = cell(num_samples,N);

% sample data one row at a time
for n = 1:num_samples
	subdata = data(data(:,i_user) == users(n), :);
	for i = N/2+1:N
		sampdata(n,i) = {floor(subdata(subdata(:, i_opp) == (i - N/2), i_correct) + 1)};
	end	
end

fprintf('Data is ready ...\n');


