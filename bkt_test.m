function [auc_value, r2, mean_pred_correct, mean_actual_correct] = bkt_test(bnet,sampdata)

fprintf('Testing ...\n');

% initialize inference engine
engine = jtree_inf_engine(bnet);

% initialize matrix that will store the prediction of each student's responses
pred_performance = zeros(size(sampdata,1),length(bnet.observed));

% initialize matrix that will store the prediction of each student's knowledge
pred_knowledge = zeros(size(sampdata,1),length(bnet.hidden));

% predict students one at a time
for s=1:size(sampdata,1)
    % predict the student's response and knowledge one opportunity at a time
    student_responses = cell(1,size(bnet.dag,1));
 
    % initialize evidence inference engine with empty response vector
    engine2 = enter_evidence(engine,student_responses);
    for o=1:length(bnet.observed)

        % predict response
        P = marginal_nodes(engine2, bnet.observed(o));
        P = P.T(2);
        pred_performance(s,o) = P;
        
        % enter the student's actual response as evidence in the network
        student_responses(bnet.observed(o)) = sampdata(s,bnet.observed(o));
        
        % predict knowledge
        engine2 = enter_evidence(engine,student_responses);
        P = marginal_nodes(engine2, bnet.hidden(o));
        P = P.T(2);
        pred_knowledge(s,o) = P;
        
    end
end

% matrix of actual responses
actual_performance = sampdata(:,bnet.observed);
nempty_index = ~cellfun(@isempty, actual_performance);
actual_performance = cell2mat(actual_performance(nempty_index)) - 1;

pred_performance_cut = pred_performance(nempty_index);

mae = mean(abs(actual_performance(:) - pred_performance_cut(:)));
rmse_value = rmse(actual_performance, pred_performance_cut);
r = corr(pred_performance_cut,actual_performance);
r2 = r * r;
auc_value = auc(pred_performance_cut, actual_performance);
mean_pred_correct = mean(pred_performance_cut);
mean_actual_correct = mean(actual_performance);

fprintf('MAE: %.4f\n',mae);
fprintf('RMSE: %.4f\n',rmse_value);
fprintf('R2: %.4f\n',r2);
fprintf('AUC: %.4f\n',auc_value);
fprintf('Predicted: %.4f\n',mean_pred_correct);
fprintf('Actual: %.4f\n',mean_actual_correct);


 