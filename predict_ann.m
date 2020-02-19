function [train_pred, test_pred] = predict_ann(training_set, training_labels, testing_set)

    testing_set = testing_set';
    training_set = training_set';
    training_labels = [abs(1 - training_labels');training_labels'];
    
    net = patternnet(15);
    net.trainParam.showWindow = 0; 
    net = train(net, training_set, training_labels);
    
    test_pred = net(testing_set);
    test_pred = (vec2ind(test_pred) - 1)';

    train_pred = net(training_set);
    train_pred = (vec2ind(train_pred) - 1)';
    
end
