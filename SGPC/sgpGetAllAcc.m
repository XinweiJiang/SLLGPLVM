function [ AccCell ] = sgpGetAllAcc( ds )
%SGPGETALLACC Summary of this function goes here
%   Detailed explanation goes here
AccCell.Models = ['Fgplvm';'SgplvmOri';'Sllgplvm'];
load('retFgplvm' ds 'Accuracy.mat');
AccCell.Fgplvm = Acc;
load('retSgplvmOri' ds 'Accuracy.mat');
AccCell.SgplvmOri = Acc;
load('retSllgplvm' ds 'Accuracy.mat');
AccCell.Sllgplvm = Acc;

end

