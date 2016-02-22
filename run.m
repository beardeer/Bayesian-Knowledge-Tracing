data_folder = 'data';
csv_files = dir(fullfile(data_folder,'*.csv'));
csv_files = {csv_files.name}';

k = 5;
results = zeros(size(csv_files, 1) * k, 5);

for i = 1:numel(csv_files)
    file_name = fullfile(data_folder,csv_files{i});
    fprintf('Processing %s ... \n', file_name);
    
    bnt = make_bkt_model;
    input_data =  get_data(file_name', bnt);
    student_num = size(input_data, 1);
    fprintf('Student number: %d\n', student_num);

    indices = crossvalind('Kfold', student_num, k);
    for r = 1:k
        test = (indices == r); train = ~test;
        test_data = input_data(test, :);
        training_data = input_data(train, :);
        bnt = make_bkt_model;
        bnet_with_learned_parameters = bkt_train(bnt, training_data);
        [auc, r2, pred_correct, actual_correct] = bkt_test(bnet_with_learned_parameters, test_data);

        results((i-1) * k + r , 1) = i;
        results((i-1) * k + r , 2) = auc;
        results((i-1) * k + r, 3) = r2;
        results((i-1) * k + r, 4) = pred_correct;
        results((i-1) * k + r, 5) = actual_correct;
    end
end

save('results.mat','results')