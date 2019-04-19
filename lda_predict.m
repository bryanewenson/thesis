function [train_pred, test_pred] = lda_predict(training_set, training_labels, testing_set)

    model = fitcdiscr(training_set, training_labels, 'discrimType', 'linear');
    train_pred = predict(model, training_set);
    test_pred = predict(model, testing_set);
    
end

