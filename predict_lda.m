function [train_pred, test_pred] = predict_lda(training_set, training_labels, testing_set)

    model = fitcdiscr(training_set, training_labels, 'discrimType', 'pseudolinear');
    train_pred = predict(model, training_set);
    test_pred = predict(model, testing_set);
    
end

