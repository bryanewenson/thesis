function [train_pred, test_pred] = predict_rf(training_set, training_labels, testing_set)

    RF_Ensemble = TreeBagger(25, training_set, training_labels);
                   
    [test_pred] = predict(RF_Ensemble, testing_set);
    test_pred = str2num(cell2mat(test_pred));
    
    [train_pred] = predict(RF_Ensemble, training_set);
    train_pred = str2num(cell2mat(train_pred));
    
end

