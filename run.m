data_folder = 'data';
csv_files = dir(fullfile(data_folder,'*.txt'));
csv_files = {csv_files.name}';

k = 5;
N = 10;
req_student_num = k*10;
results = zeros(size(csv_files, 1) * k, 10);

for i = 1:numel(csv_files)
    file_name = fullfile(data_folder,csv_files{i});
    fprintf('Processing %d/%d: %s ... \n', i, numel(csv_files), file_name);
    % I just want to split a string ... and THIS IS REALLY UGLY!!
    splited = regexp(file_name, '\', 'split');
    splited = regexp(char(splited(1,2)), '\.', 'split');
    
    bnt = make_bkt_model(N);
    input_data =  get_data(file_name', bnt);
    
    student_num = size(input_data, 1);
    fprintf('Student number: %d\n', student_num);
    if student_num < req_student_num
        continue
    end
    
    indices = crossvalind('Kfold', student_num, k);
    for r = 1:k
        fprintf('#%d fold ... \n', r);
        test = (indices == r); train = ~test;
        test_data = input_data(test, :);
        training_data = input_data(train, :);
        bnt = make_bkt_model(N);
        [bnt_learned, f_prior, f_learn, f_forget, f_guess, f_slip] = bkt_train(bnt, training_data);
        [auc, r2, pred_correct, actual_correct] = bkt_test(bnt_learned, test_data);

        results((i-1) * k + r, 1) = str2double(char(splited(1,1)));
        results((i-1) * k + r, 2) = r;
        results((i-1) * k + r, 3) = auc;
        results((i-1) * k + r, 4) = r2;
        results((i-1) * k + r, 5) = pred_correct;
        results((i-1) * k + r, 6) = actual_correct;
        results((i-1) * k + r, 7) = f_prior;
        results((i-1) * k + r, 8) = f_learn;
        results((i-1) * k + r, 9) = f_guess;
        results((i-1) * k + r, 10) = f_slip;
    end
end

save('results_0229.mat','results')