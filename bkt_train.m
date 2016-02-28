function [bnet, f_prior, f_learn, f_forget, f_guess, f_slip] = bkt_train(bnet, sampdata)

fprintf('Training ...\n');
% filter out data points of the hidden variables
sampdata(:,bnet.hidden) = cell(size(sampdata,1),length(bnet.hidden));

% intial values for EM parameter learning
i_prior = 0.30;
i_learn = 0.20;
i_forget = 0.0;
i_guess = 0.20;
i_slip = 0.08;

% prior
bnet.CPD{1} = tabular_CPD(bnet, bnet.rep_of_eclass(1), 'CPT', [1-i_prior i_prior]);

% learn/forget
bnet.CPD{2} = tabular_CPD(bnet, bnet.rep_of_eclass(2), 'CPT', [1-i_learn i_forget i_learn 1-i_forget]);

% guess/slip
bnet.CPD{3} = tabular_CPD(bnet, bnet.rep_of_eclass(3), 'CPT', [1-i_guess i_slip i_guess 1-i_slip]);

% initialize inference engine

engine = jtree_inf_engine(bnet);

% max iterations for EM parameter fitting
max_iter = 200;

% learn parameters

[bnet, LLtrace] = learn_params_em(engine, sampdata',max_iter);

% values of fit parameters
f_prior = CPD_to_CPT(bnet.CPD{1});
f_prior = f_prior(2);

f_trans = CPD_to_CPT(bnet.CPD{2});
f_learn = f_trans(3);
f_forget = f_trans(2);

f_emit = CPD_to_CPT(bnet.CPD{3});
f_guess = f_emit(3);
f_slip = f_emit(2);

fprintf('Intial params:\t prior: %.3f, learn: %.3f, forget: %.3f, guess: %.3f, slip: %.3f\n',...
   i_prior, i_learn, i_forget, i_guess, i_slip);

fprintf('Learned params:\t prior: %.3f, learn: %.3f, forget: %.3f, guess: %.3f, slip: %.3f\n',...
   f_prior, f_learn, f_forget, f_guess, f_slip);

