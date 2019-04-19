function [train_pred, test_pred] = svm_predict(training_set, training_labels, testing_set)

    model=fitcsvm(training_set, training_labels);
    train_pred = predict(model, training_set);
    test_pred = predict(model, testing_set);
    
end

